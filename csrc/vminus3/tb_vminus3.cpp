#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vvminus3.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;

static Vvminus3 *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vvminus3;

    contextp->traceEverOn(true);
    top->trace(tfp, 0);
    tfp->open("dump.vcd");
}

void simExit() {
    stepAndDumpWave();;
    tfp->close();

    delete top;
    delete tfp;
    delete contextp;
}

int main() {
    int i, j;

    simInit();

    for (i = 0; i < 2; i++) {
        top->en = i;
        for (j = 0; j < 10; j++) {
            top->clk = 1;
            stepAndDumpWave();
            top->clk = 0;
            stepAndDumpWave();
        }
    }

    simExit();

    return 0;
}
