interface Options {
    delimiters?: [string, string];
    values: {
        [key: string]: any;
    };
}
interface Results {
    code: string;
}
export default function replace(options: Options): {
    name: string;
    transform(code: string, id: string): Results;
};
export {};
