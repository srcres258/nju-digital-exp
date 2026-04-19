#include <nvboard.h>
#include "Vtop.h"

void nvboard_bind_all_pins(Vtop *top);

int main() {
    Vtop *top;

    top = new Vtop;
    nvboard_bind_all_pins(top);
    nvboard_init();

    while (1) {
        nvboard_update();
        top->eval();
    }

    delete top;

    return 0;
}
