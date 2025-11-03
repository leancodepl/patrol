import { Server, Socket } from 'net';
export type HandlerResult = {
    description: string;
    error?: any;
    response?: string | object | boolean;
};
export declare const openSockets: Set<Socket>;
export declare function handleResult(socket: Socket, type: string, hrFn: () => Promise<HandlerResult>, mode: 'json' | 'v8'): Promise<void>;
export declare function startServer(): Promise<Server>;
//# sourceMappingURL=server.d.ts.map