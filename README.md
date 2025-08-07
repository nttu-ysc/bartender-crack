# Bartender Crack

This project provides a crack for Bartender, designed to run automatically in the background on macOS.

## Features

*   Automated installation and setup.
*   Schedules the crack to run daily at a specified time.
*   Easy uninstallation.

## Installation

To install Bartender Crack, follow these steps:

1.  **Run the installation script:**

    ```bash
    curl -sSL https://raw.githubusercontent.com/nttu-ysc/bartender-crack/main/install.sh | bash
    ```

    The script will prompt you to enter the desired hour (0-23) and minute (0-59) for the daily execution of the crack.

## Usage

Once installed, Bartender Crack will automatically run daily at the time you specified during installation.

To view the logs, you can use the following command:

```bash
tail -f $HOME/.bartender-crack/bartender_crack.log
```

## Uninstallation

To uninstall Bartender Crack, execute the following command:

```bash
curl -sSL https://raw.githubusercontent.com/nttu-ysc/bartender-crack/main/uninstall.sh | bash
```

This command will download and run the uninstallation script from the GitHub repository, which will remove all installed files and services.

## Troubleshooting

*   If you encounter issues during installation, ensure you have a stable internet connection.
*   If the crack is not running as expected, check the log file for errors.
*   For any other problems, please refer to the project's GitHub issues page.
