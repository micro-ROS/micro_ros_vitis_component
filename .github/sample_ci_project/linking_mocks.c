
// newlib stubs
void _exit(int status) {}
void _kill(int pid, int sig) {}
int _getpid(void) { return 1; }
void _sbrk(void) {}
void _close(void) {}
void _fstat(void) {}
void _isatty(void) {}
void _lseek(void) {}
void _read(void) {}
void _write(void) {}
void _open(void) {}
void _wait(void) {}
void _unlink(void) {}
void _gettimeofday(void) {}

void usleep(int usec) {}

// freeRTOS stubs
void vTaskDelay(int ticks) {}
void vTaskSetTimeOutState(void *xTimeOut) {}

// lwIP stubs
void lwip_socket(void) {}
void lwip_bind(void) {}
void lwip_htons(void) {}
void lwip_htonl(void) {}
void lwip_close(void) {}
void ipaddr_addr(void) {}
void lwip_setsockopt(void) {}
void lwip_sendto(void) {}
void lwip_recvfrom(void) {}
void lwip_recv(void) {}

// Compiler stubs
unsigned int __atomic_exchange_4(volatile void * a, unsigned int b,  int c){}
void __sync_synchronize(void) {}