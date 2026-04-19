#include <nvboard.h>
#include "Vfulladder.h"

void nvboard_bind_all_pins(Vfulladder *top);

int main() {
    Vfulladder *dut;

    dut = new Vfulladder;
    nvboard_bind_all_pins(dut);
    nvboard_init();

    while (1) {
        nvboard_update();
        dut->eval();
    }

    delete dut;

    return 0;
}