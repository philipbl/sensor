from distutils.core import setup, Extension
import subprocess

# Make wiringPi library
# Make wiringPiDev library

with subprocess.Popen(["make", "all"], cwd="wiringPi/wiringPi", stdout=subprocess.PIPE) as proc:
    print(proc.stdout.read().decode('utf-8'))

with subprocess.Popen(["make", "all"], cwd="wiringPi/devLib", stdout=subprocess.PIPE) as proc:
    print(proc.stdout.read().decode('utf-8'))

# setup(
#     ext_modules=[Extension(name="sensor",
#                            sources=["_sensor.c"],
#                            include_dirs=["wiringPi/wiringPi", "wiringPi/devLib"],
#                            libraries=["wiringPi", "wiringPiDev"])]
# )
