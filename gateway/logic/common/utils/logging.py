"""
Logging utilities for the Analytics Toolbox Gateway
"""

import logging
import sys
from pathlib import Path
from typing import Optional


class ColoredFormatter(logging.Formatter):
    """Formatter that adds colors to log levels"""

    COLORS = {
        "DEBUG": "\033[36m",  # Cyan
        "INFO": "\033[32m",  # Green
        "WARNING": "\033[33m",  # Yellow
        "ERROR": "\033[31m",  # Red
        "CRITICAL": "\033[35m",  # Magenta
        "RESET": "\033[0m",  # Reset
    }

    def format(self, record):
        log_color = self.COLORS.get(record.levelname, self.COLORS["RESET"])
        reset = self.COLORS["RESET"]

        # Color the level name
        record.levelname = f"{log_color}{record.levelname}{reset}"

        return super().format(record)


def setup_logger(
    name: str = "gateway",
    level: int = logging.INFO,
    log_file: Optional[Path] = None,
    colored: bool = True,
) -> logging.Logger:
    """
    Setup a logger with console and optional file output

    Args:
        name: Logger name
        level: Logging level
        log_file: Optional path to log file
        colored: Use colored output for console

    Returns:
        Configured logger
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)

    # Remove existing handlers
    logger.handlers.clear()

    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(level)

    if colored:
        console_format = ColoredFormatter("%(levelname)s - %(message)s")
    else:
        console_format = logging.Formatter("%(levelname)s - %(message)s")

    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)

    # File handler (if specified)
    if log_file:
        log_file.parent.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(level)
        file_format = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        file_handler.setFormatter(file_format)
        logger.addHandler(file_handler)

    return logger


def get_logger(name: str = "gateway") -> logging.Logger:
    """
    Get or create a logger

    Args:
        name: Logger name

    Returns:
        Logger instance
    """
    logger = logging.getLogger(name)

    # Setup default logger if not configured
    if not logger.handlers:
        setup_logger(name)

    return logger
