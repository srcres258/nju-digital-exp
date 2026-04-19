#include <nvboard.h>
#include "Vregister4.h"

Vregister4 *top = nullptr;

void nvboard_bind_all_pins(Vregister4 *top);

void single_cycle() {
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
}

int main() {
    top = new Vregister4;
    nvboard_bind_all_pins(top);
    nvboard_init();

    while (true) {
        nvboard_update();
        single_cycle();
    }

    delete top;

    return 0;
}
