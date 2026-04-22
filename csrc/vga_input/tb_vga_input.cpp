#include <nvboard.h>
#include "Vvga_input.h"
Vvga_input *top = nullptr;
void nvboard_bind_all_pins(Vvga_input *top);

void single_cycle() {
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
}

void reset(int n) {
    top->rst = 1;
    while (n-- > 0) single_cycle();
    top->rst = 0;
}

int main() {
    top = new Vvga_input;
    nvboard_bind_all_pins(top);
    nvboard_init();
    reset(10);
    while (1) {
        nvboard_update();
        single_cycle();
    }
    delete top;
    return 0;
}
