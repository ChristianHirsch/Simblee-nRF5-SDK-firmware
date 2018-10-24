# Simblee firmware based on nRF5 SDK
This is a simple Makefile firmware for the Simblee SoC based on the Nordic nRF5 SDK. The example is a modified version of the nRF5 SDK [UART Example](https://infocenter.nordicsemi.com/index.jsp?topic=%2Fcom.nordic.infocenter.sdk51.v9.0.0%2Fuart_example.html)

## Prerequisite
- Install Arduino and the [Simblee IDE](https://www.simblee.com/Simblee_Quickstart_Guide_v1.1.0.pdf).
- Install the [nRF5 SDK](https://www.nordicsemi.com/eng/Products/Bluetooth-low-energy/nRF5-SDK).
- Modify the path' in the Makefile to point to the Simblee IDE and nRF5 SDK.

## Compile
```
make
```

## Flash firmware to Simblee
```
make upload
```
