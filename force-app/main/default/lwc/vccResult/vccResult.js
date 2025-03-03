export const ResultKind = {
    ERR: "ERR",
    OK: "OK"
};

export class Result {
    value;
    kind;

    static fromApex(result) {
        switch (result?.kindString) {
            case ResultKind.ERR:
                return new Err(result?.value);
            case ResultKind.OK:
                return new Ok(result?.value);
        }
        throw new Error("Unable to resolve apex response into Result type.");
    }

    static ok(value) {
        return new Ok(value);
    }

    static err(value) {
        return new Err(value);
    }

    static isResult(object) {
        return object instanceof Result;
    }

    static isOk(result) {
        return Result.isResult(result) && result instanceof Ok;
    }

    static isErr(result) {
        return Result.isResult(result) && result instanceof Err;
    }

    isOk() {
        return Result.isOk(this);
    }

    isErr() {
        return Result.isErr(this);
    }
}

export class Ok extends Result {
    static from(value) {
        return new Ok(value);
    }

    constructor(value) {
        super();
        this.kind = ResultKind.OK;
        this.value = value;
    }
}

export class Err extends Result {
    static from(value) {
        return new Err(value);
    }

    constructor(value) {
        super();
        this.kind = ResultKind.ERR;
        this.value = value;
    }
}
