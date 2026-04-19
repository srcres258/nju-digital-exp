#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vdecode38.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;

static Vdecode38 *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vdecode38;

    contextp->traceEverOn(true);
    top->trace(tfp, 0);
    tfp->open("dump.vcd");
}

void simExit() {
    stepAndDumpWave();
    tfp->close();

    delete top;
    delete tfp;
    delete contextp;
}

int main() {
    int i, j;

    simInit();

    for (i = 0; i <= 0b1; i++) {
        top->en = i;
        for (j = 0; j <= 0b111; j++) {
            top->x = j;
            stepAndDumpWave();
        }
    }

    simExit();

    return 0;
}
