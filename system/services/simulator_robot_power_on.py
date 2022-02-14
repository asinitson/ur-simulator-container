import socket
import time

DELAY_BEFORE_CHECKING_STATE_SEC: float = 3.0
DELAY_BEFORE_RECONNECTING_SEC: float = 3.0
BUFFER_SIZE: int = 1024

def log(message: str):
    print(f'### {message}')

log('================== Universal Robot simulator: Powering on')

while True:
    try:
        log('Connecting to robot')
        dashboard_connection = socket.create_connection(
            ("127.0.0.1", 29999),
            timeout=30)
        dashboard_connection.recv(BUFFER_SIZE)
        break
    except ConnectionRefusedError as error:
        log(error)
        log(f'Waiting for {DELAY_BEFORE_RECONNECTING_SEC} seconds...')
        time.sleep(DELAY_BEFORE_RECONNECTING_SEC)

while True:
    log('Sending power on commands to robot')
    dashboard_connection.send(b"power on\n")
    dashboard_connection.recv(BUFFER_SIZE)
    dashboard_connection.send(b"brake release\n")
    dashboard_connection.recv(BUFFER_SIZE)
    dashboard_connection.send(b"robotmode\n")
    log('Checking robot state')
    state = dashboard_connection.recv(BUFFER_SIZE).decode("utf-8")
    robot_is_powered_on = "RUNNING" in state
    if robot_is_powered_on:
        break
    else:
        log(f"Wrong robot state: '{state}'")
        log('Robot is not running')
        log(f'Waiting for {DELAY_BEFORE_CHECKING_STATE_SEC} seconds...')
        time.sleep(DELAY_BEFORE_CHECKING_STATE_SEC)

log('================== Universal Robot simulator: successfully powered on')
