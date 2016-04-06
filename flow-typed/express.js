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
  declare type App = {
    use: (arg: any) => App;
    get: (path: string, handler: (req: Req, res: Res) => void) => App;
  }

  declare class Express {
    (): App
  }

  declare var exports: Express;
}
