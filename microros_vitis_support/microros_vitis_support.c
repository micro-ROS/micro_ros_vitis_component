#include "FreeRTOS.h"
#include "task.h"
#include <time.h>

#include <rmw_microros/rmw_microros.h>
#include <rcl/rcl.h>

// Transport signatures
bool vitis_lwip_socket_transport_open(struct uxrCustomTransport * transport);
bool vitis_lwip_socket_transport_close(struct uxrCustomTransport * transport);
size_t vitis_lwip_socket_transport_write(struct uxrCustomTransport* transport, const uint8_t * buf, size_t len, uint8_t * err);
size_t vitis_lwip_socket_transport_read(struct uxrCustomTransport* transport, uint8_t* buf, size_t len, int timeout, uint8_t* err);

// Memory allocation
void * vitis_allocate(size_t size, void * state)
{
    return malloc(size);
}

void vitis_deallocate(void * pointer, void * state)
{
    free(pointer);
}

void * vitis_reallocate(void * pointer, size_t size, void * state)
{
    return realloc(pointer, size);
}

void * vitis_zero_allocate(size_t number_of_elements, size_t size_of_element, void * state)
{
    return calloc(number_of_elements, size_of_element);
}

// Clock handling
#define MICROSECONDS_PER_SECOND    ( 1000000LL )                                   /**< Microseconds per second. */
#define NANOSECONDS_PER_SECOND     ( 1000000000LL )                                /**< Nanoseconds per second. */
#define NANOSECONDS_PER_TICK       ( NANOSECONDS_PER_SECOND / configTICK_RATE_HZ ) /**< Nanoseconds per FreeRTOS tick. */

void UTILS_NanosecondsToTimespec( int64_t llSource,
                                  struct timespec * const pxDestination )
{
    long lCarrySec = 0;

    /* Convert to timespec. */
    pxDestination->tv_sec = ( time_t ) ( llSource / NANOSECONDS_PER_SECOND );
    pxDestination->tv_nsec = ( long ) ( llSource % NANOSECONDS_PER_SECOND );

    /* Subtract from tv_sec if tv_nsec < 0. */
    if( pxDestination->tv_nsec < 0L )
    {
        /* Compute the number of seconds to carry. */
        lCarrySec = ( pxDestination->tv_nsec / ( long ) NANOSECONDS_PER_SECOND ) + 1L;

        pxDestination->tv_sec -= ( time_t ) ( lCarrySec );
        pxDestination->tv_nsec += lCarrySec * ( long ) NANOSECONDS_PER_SECOND;
    }
}

int clock_gettime(clockid_t unused, struct timespec *tp)
{

    ( void ) unused;

    TimeOut_t xCurrentTime = { 0 };
    uint64_t ullTickCount = 0ULL;

    vTaskSetTimeOutState( &xCurrentTime );

    ullTickCount = ( uint64_t ) ( xCurrentTime.xOverflowCount ) << ( sizeof( TickType_t ) * 8 );

    ullTickCount += xCurrentTime.xTimeOnEntering;

    UTILS_NanosecondsToTimespec( ( int64_t ) ullTickCount * NANOSECONDS_PER_TICK, tp );

    return 0;
}

// Micro-ROS configuration
void configure_microros()
{
	rmw_uros_set_custom_transport(
		true,
		NULL,
		vitis_lwip_socket_transport_open,
		vitis_lwip_socket_transport_close,
		vitis_lwip_socket_transport_write,
		vitis_lwip_socket_transport_read
	);

    rcl_allocator_t vitis_allocator = rcutils_get_zero_initialized_allocator();
    vitis_allocator.allocate = vitis_allocate;
    vitis_allocator.deallocate = vitis_deallocate;
    vitis_allocator.reallocate = vitis_reallocate;
    vitis_allocator.zero_allocate =  vitis_zero_allocate;

    if (!rcutils_set_default_allocator(&vitis_allocator)) {
        printf("Error on default allocators (line %d)\n", __LINE__);
    }
}
