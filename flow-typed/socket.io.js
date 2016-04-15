// @flow

declare type Socket = {
  emit(event: string, ...args: Array<any>) : Socket;
  on(event: string, fn: Function): Socket;
}

declare module "socket.io" {
  declare type SocketIO = {
    on(event: 'connection', listener: (socket: Socket) => void): any;
  }

  declare var exports: (server: any) => SocketIO;
}
