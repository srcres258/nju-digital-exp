#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vdecode24.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;

static Vdecode24 *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vdecode24;

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
    top->x = 0b00;
    stepAndDumpWave();

    top->x = 0b01;
    stepAndDumpWave();

    top->x = 0b10;
    stepAndDumpWave();

    top->x = 0b11;
    stepAndDumpWave();

    top->en = 0b1;
    top->x = 0b00;
    stepAndDumpWave();

    top->x = 0b01;
    stepAndDumpWave();

    top->x = 0b10;
    stepAndDumpWave();

    top->x = 0b11;
    stepAndDumpWave();

    simExit();

    return 0;
}
