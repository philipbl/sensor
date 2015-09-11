# Sensor

This project is intended to be used by anyone with a temperature / humidity sensor. I followed [these instructions][1] to build one. This project provides the software for writing sensor data and reading it in different formats and on different devices. It consists of four parts: collection, server, web client, and iOS app.

## Collection
This is a python script that takes care of reading from the sensor and writing it to a database.

## Server
This is a python server that presents a RESTful(ish) API. It reads from the database, processes the data, and sends it to the requester.

## Web Client
Displays current conditions and graphs of data from the sensor.

## iOS App
Displays current conditions and graphs of data from the sensor on iOS.

[1]: http://www.instructables.com/id/Raspberry-Pi-Temperature-Humidity-Network-Monitor/
