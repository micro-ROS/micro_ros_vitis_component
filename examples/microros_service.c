#include <microros_vitis_support.h>

#include <FreeRTOS.h>
#include <task.h>

#include <stdio.h>
#include <rcl/rcl.h>
#include <rcl/error_handling.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>

#include <example_interfaces/srv/add_two_ints.h>

#define RCCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){while(true){};}}
#define RCSOFTCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){}}

void service_callback(const void * req, void * res){
  example_interfaces__srv__AddTwoInts_Request * req_in = (example_interfaces__srv__AddTwoInts_Request *) req;
  example_interfaces__srv__AddTwoInts_Response * res_in = (example_interfaces__srv__AddTwoInts_Response *) res;

  res_in->sum = req_in->a + req_in->b;
}

void microros_add_two_ints_service() {
    configure_microros();

    rcl_allocator_t allocator = rcl_get_default_allocator();
    rclc_support_t support;;

    // init micro_ros
    RCCHECK(rclc_support_init(&support, 0, NULL, &allocator));

    // create node
    rcl_node_t node;
    RCCHECK(rclc_node_init_default(&node, "microros_node", "", &support));

    // create service
    rcl_service_t service;
    RCCHECK(rclc_service_init_default(
        &service,
        &node,
        ROSIDL_GET_SRV_TYPE_SUPPORT(example_interfaces, srv, AddTwoInts),
        "/addtwoints"));

    // create executor
    rclc_executor_t executor;
    RCCHECK(rclc_executor_init(&executor, &support.context, 1, &allocator));

    example_interfaces__srv__AddTwoInts_Response res;
    example_interfaces__srv__AddTwoInts_Request req;
    RCCHECK(rclc_executor_add_service(&executor, &service, &req, &res, service_callback));

    while (true)
    {
        RCSOFTCHECK(rclc_executor_spin_some(&executor, RCL_MS_TO_NS(100)));
        vTaskDelay(100 / portTICK_PERIOD_MS);
    }
}