#include <nvboard.h>
#include "Vencode83_seg.h"

void nvboard_bind_all_pins(Vencode83_seg *top);

int main() {
    Vencode83_seg *top;

    top = new Vencode83_seg;
    nvboard_bind_all_pins(top);
    nvboard_init();

    while (1) {
        nvboard_update();
        top->eval();
    }

    delete top;

    return 0;
}
