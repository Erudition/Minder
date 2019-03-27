export declare const jestPreprocessor: {
    process(sourceText: string, filePath: string, jestConfig: {
        rootDir: string;
    }): string | {
        code: string;
        map: any;
    };
    getCompilerOptions(rootDir: string): any;
    getCacheKey(code: string, filePath: string, jestConfigStr: string, transformOptions: {
        instrument: boolean;
        rootDir: string;
    }): string;
};
