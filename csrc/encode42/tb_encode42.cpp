#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vencode42.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;

static Vencode42 *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vencode42;

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
    simInit();

    top->en = 0b0;
    top->x = 0b0000;
    stepAndDumpWave();

    top->x = 0b0001;
    stepAndDumpWave();

    top->x = 0b0010;
    stepAndDumpWave();

    top->x = 0b0100;
    stepAndDumpWave();

    top->x = 0b1000;
    stepAndDumpWave();

    top->en = 0b1;
    top->x = 0b0000;
    stepAndDumpWave();

    top->x = 0b0001;
    stepAndDumpWave();

    top->x = 0b0010;
    stepAndDumpWave();

    top->x = 0b0100;
    stepAndDumpWave();

    top->x = 0b1000;
    stepAndDumpWave();

    simExit();

    return 0;
}
