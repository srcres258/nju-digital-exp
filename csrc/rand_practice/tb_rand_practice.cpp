#include <nvboard.h>
#include "Vrand_practice.h"

Vrand_practice *top = nullptr;

void nvboard_bind_all_pins(Vrand_practice *top);

int main() {
    top = new Vrand_practice;
    nvboard_bind_all_pins(top);
    nvboard_init();

    while (true) {
        nvboard_update();
        top->eval();
    }

    delete top;

    return 0;
}
