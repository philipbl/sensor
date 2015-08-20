#include <Python.h>

#include <stdio.h>
#include <wiringPi.h>
#include <maxdetect.h>
#include <time.h>

#define RHT03_PIN   7
#define CYCLETIME   60
#define RETRIES     3

static PyObject *writer = NULL;
static volatile int running = 1;

void intHandler(int dummy) {
    running = 0;
}

static void write_sensor_data(float temperature, float humidity) {
    PyObject *arglist;
    PyObject *result;

    arglist = Py_BuildValue("(ff)", temperature, humidity);
    result = PyObject_CallObject(writer, arglist);
    Py_DECREF(arglist);
    Py_DECREF(result);
}

static void read_sensor_data() {
    int temp;
    int oldtemp;
    int rh;

    oldtemp = 500;

    wiringPiSetup();
    piHiPri(55);

    while (running) {
        // wait for an interval to start
        while ((((int)time(NULL)) % CYCLETIME) && running) { delay(100); }

        temp = rh = -1;
        int loop = RETRIES;

        int status = readRHT03(RHT03_PIN, &temp, &rh);
        while ((!status) && loop-- && running)
        {
            printf("-Retry-");
            fflush(stdout);
            delay(3000);
            status = readRHT03(RHT03_PIN, &temp, &rh);
        }

        int difftemp = temp - oldtemp;

        if (temp > oldtemp && difftemp > 100) {
            printf("The sensor returned a bad reading!\n");
            fflush(stdout);
        }
        else {
            write_sensor_data(temp / 10.0, rh / 10.0);
            oldtemp = temp;
        }

        // wait for the rest of that interval to finish
        while (!(((int)time(NULL)) % CYCLETIME) && running) { delay(100); }
    }
}

static PyObject * sensor_read(PyObject *self, PyObject *args)
{
    // Register ctrl-C handler
    signal(SIGINT, intHandler);

    // The callback from the caller
    // This gets called when new data has been read from the sensor
    PyObject *temp;

    // Parse the arguments to the function
    if (!PyArg_ParseTuple(args, "O", &temp)) {
        return NULL;
    }

    // Make sure the argument is a callback
    if (!PyCallable_Check(temp)) {
        PyErr_SetString(PyExc_TypeError, "parameter must be callable");
        return NULL;
    }

    Py_XINCREF(temp);
    Py_XDECREF(writer);
    writer = temp;

    read_sensor_data();

    Py_RETURN_NONE;
}

static PyMethodDef SensorMethods[] = {
    {"read", sensor_read, METH_VARARGS, "Test"},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef sensormodule = {
   PyModuleDef_HEAD_INIT,
   "sensor",   /* name of module */
   NULL, /* module documentation, may be NULL */
   -1,       /* size of per-interpreter state of the module,
                or -1 if the module keeps state in global variables. */
   SensorMethods
};

PyMODINIT_FUNC
PyInit_sensor(void)
{
    return PyModule_Create(&sensormodule);
}
