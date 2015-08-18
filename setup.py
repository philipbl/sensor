from distutils.core import setup, Extension
import subprocess

setup(
    ext_modules=[Extension(name="sensor",
                           sources=["_sensor.c"],
                           libraries=["wiringPi", "wiringPiDev"])]
)
