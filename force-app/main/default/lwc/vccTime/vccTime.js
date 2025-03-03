/**
 * Time-related methods and data types.
 * Not designed with any measured guaranteed time accuracy in mind.
 */

import ExposedPromise from "c/exposedPromise";

const TimeType = {
    Minutes: "Minutes",
    Seconds: "Seconds",
    Milliseconds: "Milliseconds",
    None: "None"
};

export class Time {
    value = 0;
    type = TimeType.None;

    static toMilliseconds(time) {
        switch (time?.type) {
            case TimeType.Minutes:
                return 60000 * time.value;
            case TimeType.Seconds:
                return 1000 * time.value;
            case TimeType.Milliseconds:
                return 1 * time.value;
            case TimeType.None:
                return 0;
            default:
                return 0;
        }
    }

    static Milliseconds = class extends Time {
        static from(number = 0) {
            return new this(number);
        }
        constructor(value) {
            super(value);
        }
    };

    static Seconds = class extends Time {
        static from(number = 0) {
            return new this(number);
        }
        constructor(value) {
            super(value);
        }
    };

    static Minutes = class extends Time {
        static from(number = 0) {
            return new this(number);
        }
        constructor(value) {
            super(value);
        }
    };

    static getType(time) {
        if (time == null || typeof time != "object") {
            return TimeType.None;
        }
        if (time instanceof Time.Minutes) {
            return TimeType.Minutes;
        }
        if (time instanceof Time.Seconds) {
            return TimeType.Seconds;
        }
        if (time instanceof Time.Milliseconds) {
            return TimeType.Milliseconds;
        }
        return TimeType.None;
    }

    static assertIsTime(time) {
        if (!(time instanceof Time)) {
            throw new Error("Object is not an instance of Time.");
        }
    }

    constructor(number) {
        if (number == null) {
            this.value = 0;
        } else if (typeof number != "number") {
            throw new Error("Time value must be a number.");
        } else {
            this.value = number;
        }
        this.type = Time.getType(this);
    }
}

export const Minutes = (number = 0) => {
    return Time.Minutes.from(number);
};

export const Seconds = (number = 0) => {
    return Time.Seconds.from(number);
};

export const Milliseconds = (number = 0) => {
    return Time.Milliseconds.from(number);
};

export class Delay {
    timeoutId;
    duration = new Time(0);
    promise;

    isActive() {
        return this.timeoutId != null && this.promise != null;
    }

    for(duration = new Time()) {
        Time.assertIsTime(duration);
        this.duration = duration;
        return this;
    }

    static for(duration = new Time()) {
        let newThis = new this();
        return newThis.for(duration);
    }

    start() {
        this.stop();
        this.timeoutId = setTimeout(this.stop.bind(this), Time.toMilliseconds(this.duration));
        this.promise = new ExposedPromise();
        return this.promise;
    }

    stop() {
        try {
            clearTimeout(this.timeoutId);
        } catch (e) {
            null;
        }
        try {
            this.promise.resolve();
        } catch (e) {
            null;
        }
        this.timeoutId = null;
        this.promise = null;
    }
}

export class Interval {
    timeout = Delay.for(new Time(0));
    frequency = new Time(0);
    doFunction = async () => {};
    intervalId;

    isRunning() {
        return this.intervalId == null;
    }

    do(func = async () => {}) {
        if (typeof func != "function") {
            throw Error('Unexpected argument type in "do" function; Expected function as first argument.');
        }
        this.doFunction = func;
        return this;
    }

    every(frequency = new Time(0)) {
        Time.assertIsTime(frequency);
        this.frequency = frequency;
        return this;
    }

    for(duration = new Time(0)) {
        Time.assertIsTime(duration);
        this.timeout = Delay.for(duration);
        return this;
    }

    static do(func = async () => {}) {
        let newThis = new this();
        return newThis.do(func);
    }

    static every(frequency = new Time(0)) {
        let newThis = new this();
        return newThis.every(frequency);
    }

    static for(duration = new Time(0)) {
        let newThis = new this();
        return newThis.for(duration);
    }

    start() {
        this.timeout.start();
        this.doInterval();
    }

    async doInterval() {
        if (!this.timeout.isActive()) {
            return;
        }
        await this.doFunction(this.stop.bind(this));
        await Delay.for(this.frequency).start();
        this.doInterval();
    }

    stop() {
        this.timeout.stop();
        this.intervalId = null;
    }
}
