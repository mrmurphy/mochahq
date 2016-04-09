// @flow

declare module "express" {

  declare type Req = {
    body: Object;
    headers: Object;
  }

  declare type Res = {
    body: mixed;
    status: Number;
  }

  declare type Handler = (req: Req, res: Res, next: any) => void;

  declare type App = {
    use: (cb: Handler) => App;
    get: (path: string, handler: (req: Req, res: Res) => void) => App;
    (): App;
  }

  declare type Express = {
    (): App;
    static(path: string): Handler;
  }

  declare var exports: Express;
}
