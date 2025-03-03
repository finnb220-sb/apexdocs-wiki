import LightningAlert from "lightning/alert";
import { APPLICATION_SCOPE, createMessageContext, MessageContext, publish, releaseMessageContext, subscribe, unsubscribe } from "lightning/messageService";
import vccMessageChannel from "@salesforce/messageChannel/vccMessageChannel__c";

class Subscription {
    context;
    subscription;
    isApplicationScope;

    constructor(isApplicationScope) {
        this.isApplicationScope = typeof isApplicationScope === "boolean" ? isApplicationScope : false;
        this.context = createMessageContext();
    }

    listen(handler) {
        if (this.isApplicationScope == true) {
            this.subscription = subscribe(this.context, vccMessageChannel, handler, { scope: APPLICATION_SCOPE });
        } else if (this.isApplicationScope == false) {
            this.subscription = subscribe(this.context, vccMessageChannel, handler);
        }
        return this;
    }

    publish(payload) {
        publish(this.context, vccMessageChannel, payload);
        return this;
    }

    release() {
        unsubscribe(this.subscription);
        releaseMessageContext(this.context);
    }
}
class Manifest {
    toUuid;
    fromUuid;
    transactionUuid;

    //swaps returns new Manifest with 'toUuid' and 'fromUuid' swapped
    getReturnManifest() {
        return new Manifest({
            fromUuid: this.toUuid,
            toUuid: this.fromUuid,
            transactionUuid: this.transactionUuid
        });
    }

    //creates a transactionUuid and returns that value
    initializeTransaction() {
        this.transactionUuid = crypto.randomUUID();
        return this.transactionUuid;
    }

    constructor({ fromUuid, toUuid, transactionUuid }) {
        this.toUuid = toUuid || null;
        this.fromUuid = fromUuid || null;
        this.transactionUuid = transactionUuid || null;
    }
}

class Packet {
    timestamp;
    payload;
    type;
    manifest;

    constructor({ type, manifest, payload, timestamp }) {
        this.manifest = new Manifest(manifest);
        this.type = type;
        this.payload = payload;
        this.timestamp = timestamp || Date.now();
    }
}

class FindClient extends Packet {
    static isFindClient(packet) {
        if (packet.type == "findClient" && typeof packet.payload == "string") {
            return true;
        }
        return false;
    }

    constructor({ manifest, clientName }) {
        super({
            type: "findClient",
            manifest: manifest,
            payload: clientName
        });
    }
}

class ClientMessage extends Packet {
    static isClientMessage(packet) {
        if (packet.type == "clientMessage") {
            return true;
        }
        return false;
    }

    constructor({ manifest, payload }) {
        super({
            type: "clientMessage",
            manifest: manifest,
            payload: payload
        });
    }
}

class ClientNotFoundError extends Error {
    constructor(clientName) {
        super(`Unable to find client named "${clientName}".`);
    }
}

class Client {
    name;
    uuid = crypto.randomUUID();
    transactionUuidToCallbackMap = new Map();
    subscription;

    constructor({ ...args }) {
        this.validateConstructorParams(args);
        this.handleConstructorParams(args);
    }

    validateConstructorParams({ name, listener }) {
        if (typeof name != "string") {
            throw "Client name is required as first parameter.";
        }
        if (typeof listener != "function") {
            throw "Message handler is required as second parameter.";
        }
    }

    async handleConstructorParams({ name, listener, isApplicationScope }) {
        this.name = name;
        this.subscription = new Subscription(isApplicationScope).listen((msg) => {
            let packet = new Packet(msg);
            let { toUuid, fromUuid, transactionUuid } = packet?.manifest;

            if (fromUuid == this.uuid) {
                return;
            }

            if (FindClient.isFindClient(packet)) {
                this.handleFindClientPacket(packet);
            }

            if (toUuid != this.uuid) {
                return;
            }

            if (ClientMessage.isClientMessage(packet)) {
                if (this.transactionUuidToCallbackMap.has(transactionUuid)) {
                    this.transactionUuidToCallbackMap.get(transactionUuid)(msg);
                    this.transactionUuidToCallbackMap.delete(transactionUuid);
                    return;
                }
                listener({
                    payload: packet.payload,
                    reply: (payload) => {
                        let returnManifest = packet?.manifest?.getReturnManifest();
                        this.publish(new ClientMessage({ manifest: returnManifest, payload: payload }));
                    }
                });
            }
        });
        this.checkForDuplicateClient(this.name);
    }

    async checkForDuplicateClient(clientName) {
        try {
            let uuid = await this.findClient(clientName, 1);
            if (uuid != null || uuid != undefined) {
                LightningAlert.open({
                    theme: "warning",
                    message: `A client with name "${clientName}" already exists.`,
                    label: "vccMessageChannel Warning"
                });
            }
        } catch (e) {}
    }

    handleFindClientPacket(packet) {
        if (packet.payload == this.name) {
            let clientMessage = new ClientMessage({
                manifest: packet?.manifest?.getReturnManifest(),
                payload: this.uuid
            });
            this.publish(clientMessage);
        }
    }

    async sendMessageTo(clientName, payload) {
        try {
            let toUuid = await this.findClient(clientName);
            let clientMessage = new ClientMessage({
                manifest: this.createManifest(toUuid),
                payload: payload
            });
            this.publish(clientMessage);
        } catch (e) {
            console.warn(e);
        }
    }

    async sendRequestTo(clientName, payload) {
        return await new Promise(async (resolve, reject) => {
            try {
                let clientMessage = this.createMessage(await this.findClient(clientName), payload);

                this.transactionUuidToCallbackMap.set(clientMessage.manifest.initializeTransaction(), (msg) => {
                    resolve(msg.payload);
                });

                this.publish(clientMessage);
            } catch (e) {
                reject(e);
            }
        });
    }

    createMessage(toUuid, payload) {
        return new ClientMessage({
            manifest: this.createManifest(toUuid),
            payload: payload
        });
    }

    async findClient(clientName, retries) {
        return await new Promise((resolve, reject) => {
            let packet = new FindClient({
                manifest: this.createManifest(null),
                clientName
            });

            let tries = 0;
            let intervalId;

            this.transactionUuidToCallbackMap.set(packet.manifest.initializeTransaction(), (msg) => {
                clearInterval(intervalId);
                resolve(msg.payload);
            });

            intervalId = setInterval(() => {
                if (tries < ((typeof retries == "number" && retries > 0 ? retries : null) || 5)) {
                    this.publish(packet);
                    tries++;
                } else {
                    clearInterval(intervalId);
                    reject(new ClientNotFoundError(clientName));
                }
            }, 1000);
        });
    }

    publish(packet) {
        try {
            this.subscription.publish(packet);
        } catch (e) {
            console.warn(e);
        }
    }

    createManifest(toUuid) {
        return new Manifest({
            fromUuid: this.uuid,
            toUuid: toUuid
        });
    }
}

export function createClient(name, listener, isApplicationScope) {
    return (function () {
        let client = new Client({ name: name, listener: listener, isApplicationScope: isApplicationScope });
        return {
            sendMessageTo: client.sendMessageTo.bind(client),
            sendRequestTo: client.sendRequestTo.bind(client),
            close: client.subscription.release.bind(client.subscription)
        };
    })();
}
