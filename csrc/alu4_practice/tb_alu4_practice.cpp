#include <nvboard.h>
#include "Valu4_practice.h"

void nvboard_bind_all_pins(Valu4_practice *top);

int main() {
    Valu4_practice top;
    nvboard_bind_all_pins(&top);
    nvboard_init();

    while (1) {
        nvboard_update();
        top.eval();
    }

    return 0;
}
