#include <nvboard.h>
#include "Vbcd7seg.h"

void nvboard_bind_all_pins(Vbcd7seg *top);

int main() {
    Vbcd7seg *top;

    top = new Vbcd7seg;
    nvboard_bind_all_pins(top);
    nvboard_init();

    while (1) {
        nvboard_update();
        top->eval();
    }

    delete top;

    return 0;
}
