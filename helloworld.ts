import { $ } from "bun";

try {
    const output = await $`echo "Hello World!"`.text();
    console.log(output);
} catch (err: any) {
    console.log(`Failed with return code: ${err.exitCode}`);
    console.log(err.stdout.toString());
    console.log(err.stderr.toString());
}

