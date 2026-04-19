#include <nvboard.h>
#include "Vmux41_practice.h"

void nvboard_bind_all_pins(Vmux41_practice *top);

int main() {
    Vmux41_practice *top;

    top = new Vmux41_practice;
    nvboard_bind_all_pins(top);
    nvboard_init();

    while (1) {
        nvboard_update();
        top->eval();
    }

    delete top;

    return 0;
}
