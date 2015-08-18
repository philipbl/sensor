import sensor

def writer(temperature, humdity):
    print(temperature)
    print(humdity)

sensor.read(writer)
