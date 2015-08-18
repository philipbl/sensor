from distutils.core import setup, Extension

setup(
    ext_modules=[Extension("sensor", ["_sensor.c"])]
)
