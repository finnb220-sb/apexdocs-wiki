import { LightningElement } from 'lwc';

/**
 * @description This class handles the setting, formatting, and incrementing of a Stopwatch situated in the Utility Bar of the Tele-EC Tracker App
 * @author Garrett Carlson : Booz Allen
 */

export default class TimerComponent extends LightningElement {
    totalSeconds = 0;
    timerInterval;
    isPaused = false;

    /**
     * @description Calculates hours, minutes, and seconds from totalSeconds. Formats totalSeconds into a readable format 00:00:00
     */
    get formattedTime() {
        const hours = Math.floor(this.totalSeconds / 3600);
        const minutes = Math.floor((this.totalSeconds % 3600) / 60);
        const seconds = this.totalSeconds % 60;
        return `${this.pad(hours)}:${this.pad(minutes)}:${this.pad(seconds)}`;
    }

    /**
     * @description Disables the start button based on total seconds
     */
    get startDisabled() {
        return this.totalSeconds > 0;
    }

    /**
     * @description Disables the pause button based on total seconds and the pause flag
     */
    get pauseDisabled() {
        return this.isPaused || this.totalSeconds === 0;
    }

    /**
     * @description Disables the resume button based on total seconds and the pause flag
     */
    get resumeDisabled() {
        return !this.isPaused || this.totalSeconds === 0;
    }

    /**
     * @description Sets a new interval that increases totalseconds each interval, called on start button press
     */
    startTimer() {
        //eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timerInterval = setInterval(() => {
            this.totalSeconds++;
        }, 1000);
    }

    /**
     * @description Clears the time interval that increments totalSeconds, thus pausing the timer. Sets the Pause flag to true, to be read by attribute
     * calls on the HTML
     */
    pauseTimer() {
        clearInterval(this.timerInterval);
        this.isPaused = true;
    }

    /**
     * @description Checks the Pause flag. Starts the timer if it is paused by calling the startTimer function, continuing its increment.
     * Defaults the pause flag
     */
    resumeTimer() {
        if (this.isPaused) {
            this.startTimer();
            this.isPaused = false;
        }
    }

    /**
     * @description Clears the current interval and resets the totalSeconds count. Returns pause flag to default. The timer is reset.
     */
    resetTimer() {
        clearInterval(this.timerInterval);
        this.totalSeconds = 0;
        this.isPaused = false;
    }

    /**
     * @description Formats the timer with a preceding zero if any part of the time interval is less than 10 ex. 10 seconds has no padding, 09 has padding
     * @param val an integer passed from formattedTime that adds a zero in front of the passed value if it is below 10, in order to make it more readable
     */
    pad(val) {
        return val < 10 ? '0' + val : val;
    }
}
