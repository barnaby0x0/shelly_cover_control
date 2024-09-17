# Shelly Cover Control Script

This script allows users to control and manage a Shelly cover (roller shutter) device using Shelly's RPC API. The script supports actions such as opening, closing, setting specific positions, and fetching the current status and configuration of the cover.

## Features

- **Open/Close/Stop**: Open, close, or stop the Shelly cover.
- **Position Control**: Set the cover to a specific position (0% - fully closed, 100% - fully open).
- **Status/Configuration Fetching**: Retrieve the current status or configuration of the cover.
- **Position Adjustments**: Increase the cover position in small increments.
- **Custom Configuration File**: Load configuration from a custom properties file via an environment variable.
- **Secure Credentials Handling**: Fetch credentials securely using the `pass` command.

## Requirements

- **curl**: Required for making HTTP requests to the Shelly API.
- **jq**: Required for parsing JSON responses.
- **pass**: A password manager used to securely fetch the Shelly device's IP and password.

## Configuration

The script relies on a properties file to define key configuration settings like the **Shelly IP address**, **password**, and other thresholds. By default, the script will load the `config.properties` file unless a different file is specified using the `PROPERTIES_FILE` environment variable.

### Example Properties File (`config.properties`)

```properties
# Shelly device information
PASS_SHELLY_IP=shelly/room3/ip
PASS_SHELLY_PASSWORD=shelly/room3/password

# Threshold for percent limit
LOW_LIMIT_FOR_PERCENT=70
```

- **PASS_SHELLY_IP**: The path in the `pass` utility where the Shelly device's IP is stored.
- **PASS_SHELLY_PASSWORD**: The path in the `pass` utility where the Shelly device's password is stored.
- **LOW_LIMIT_FOR_PERCENT**: The threshold percentage used when adjusting the cover position incrementally.

## Usage

### Running the Script

```bash
./shelly_cover_control.sh {command} [options]
```

You can also specify a custom properties file by setting the `PROPERTIES_FILE` environment variable:

```bash
PROPERTIES_FILE=my_custom_config.properties ./shelly_cover_control.sh {command} [options]
```

If no custom properties file is provided, it will default to `config.properties`.

### Available Commands

- **get_status [pretty]**: Retrieve the current status of the cover.
  - `pretty`: Optionally format the output using `jq`.

  ```bash
  ./shelly_cover_control.sh get_status
  ./shelly_cover_control.sh get_status pretty
  ```

- **get_configuration**: Fetch the current configuration of the Shelly cover.

  ```bash
  ./shelly_cover_control.sh get_configuration
  ```

- **set_position [position]**: Set the cover to a specific position (0-100). The position must be a valid integer between 0 and 100.

  ```bash
  ./shelly_cover_control.sh set_position 50  # Moves cover to 50% open
  ```

- **open**: Fully opens the cover.

  ```bash
  ./shelly_cover_control.sh open
  ```

- **close**: Fully closes the cover.

  ```bash
  ./shelly_cover_control.sh close
  ```

- **stop**: Stops the cover’s current movement.

  ```bash
  ./shelly_cover_control.sh stop
  ```

- **quarter**: Increase the cover position by 1%, only if the current position is below 70%.

  ```bash
  ./shelly_cover_control.sh quarter
  ```

- **half**: Increase the cover position by 2%, only if the current position is below 70%.

  ```bash
  ./shelly_cover_control.sh half
  ```

- **get {temp|pos|state}**: Retrieve specific information from the cover’s status:
  - `temp`: Get the current temperature in Celsius.
  - `pos`: Get the current position percentage.
  - `state`: Get the current state (open, closed, stopped).

  ```bash
  ./shelly_cover_control.sh get temp   # Retrieves current temperature
  ./shelly_cover_control.sh get pos    # Retrieves current position
  ./shelly_cover_control.sh get state  # Retrieves current state
  ```

### Example Usage

```bash
# Fully open the cover
./shelly_cover_control.sh open

# Fully close the cover
./shelly_cover_control.sh close

# Set the cover to 75% open
./shelly_cover_control.sh set_position 75

# Get the current status (formatted with jq)
./shelly_cover_control.sh get_status pretty

# Increase the cover position by 1% (if current position is less than 70%)
./shelly_cover_control.sh quarter
```

### Exit Codes

- **0**: Success
- **1**: Invalid command, argument, or failure to load properties file.

## Custom Configuration via `PROPERTIES_FILE`

By default, the script uses `config.properties` for configuration. However, you can specify a custom properties file by setting the `PROPERTIES_FILE` environment variable. This allows for flexibility in different environments.

#### Example:

```bash
PROPERTIES_FILE=my_custom_config.properties ./shelly_cover_control.sh get_status
```

## Secure Credentials Handling

This script uses the `pass` utility to securely manage and retrieve the Shelly device's IP and password. Ensure that you have the appropriate credentials stored in `pass` at the paths specified in the properties file.

To check your stored credentials:

```bash
pass show shelly/room3/ip        # Retrieves the Shelly device's IP
pass show shelly/room3/password  # Retrieves the Shelly device's password
```

## Dependencies

- **curl**: Used to make HTTP requests to the Shelly API.
- **jq**: Required for parsing JSON responses.
- **pass**: Required for securely retrieving the Shelly device's IP and password.

## Troubleshooting

1. **"Error: Properties file not found"**: Ensure the `config.properties` file exists or set the correct path using the `PROPERTIES_FILE` environment variable.
   
2. **"Error: Unable to retrieve Shelly IP or password"**: Ensure that the `pass` utility is properly configured and the paths in the properties file point to valid entries in your password store.

3. **Invalid Position**: Ensure that the position value provided for `set_position` is an integer between 0 and 100.

4. **Connectivity Issues**: If the script fails to interact with the Shelly device, check if the device is reachable at the specified IP:

   ```bash
   curl -s --digest -X POST http://<SHELLY_IP>/rpc/Cover.GetStatus --user admin:<SHELLY_PASS>
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

