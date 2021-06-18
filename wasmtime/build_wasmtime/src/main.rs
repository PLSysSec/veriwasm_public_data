use std::collections::VecDeque;
use std::env;
use std::fs;
use std::io::{self, Error, ErrorKind};
use std::path::{Path, PathBuf};
use std::process::exit;
use std::process::Command;

// ../../../wasmtime/target/debug/wasmtime compile --cranelift --target aarch64-unknown-linux  wasm/exit125_wasi_snapshot0.wat -o test123.cwasm

fn compile_file(filepath: &str, wasmtime_path: &str, arch_str: &str, base_path: &str) -> bool {
    let out_suffix = &filepath[base_path.len()..];
    let output_path = &format!("../bin/{}", out_suffix);

    //Make parent directory if necessary
    fs::create_dir_all(Path::new(output_path).parent().unwrap());
    println!("Compiling {} => {}", filepath, output_path);
    let cmd_output = Command::new(wasmtime_path)
        .args(&[
            "compile",
            "--cranelift",
            "--target", arch_str,
            filepath,
            "-o", output_path,
        ])
        .output()
        .unwrap();

    println!("Compilation Complete: {}", cmd_output.status);
    println!("{:?}", cmd_output);
    // println!("{:?}", cmd_output.stdout.to_string());
    // println!("{:?}", cmd_output.stderr.to_string());
    match cmd_output.status.code().unwrap() {
        0 => return true,
        255 => return false,
        _ => return false,
    }
}

//iterate over every directory, calling compile_file on each test
fn iter_dirs(base_path: &str, wasmtime_path: &str, arch_str: &str) -> io::Result<()> {
    let mut count = 0;
    let mut q: VecDeque<PathBuf> = VecDeque::new();
    q.push_front(PathBuf::from(base_path));
    while !q.is_empty() {
        let path = q.pop_front().unwrap();
        match path.to_str() {
            Some(p) => {
                if path.is_dir() {
                    for entry in fs::read_dir(path)? {
                        q.push_back(entry?.path());
                    }
                } else {
                    println!("File #{:?}", count);
                    compile_file(p, wasmtime_path, arch_str, base_path);
                    count += 1;
                }
            }
            None => return Err(Error::new(ErrorKind::Other, "bad file name")),
        }
    }
    Ok(())
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 4 {
        println!(
            "Usage: cargo run -- <path/to/wasmtime> <path/to/dir_to_check> <target arch string>"
        );
        println!("Available target arch strings: x86_64-unknown-linux aarch64-unknown-linux");
        exit(-1);
    }

    let wasmtime_path = &args[1];
    let path = &args[2];
    let arch_str = &args[3];
    println!(
        "Compiling {} with {} under arch {}",
        path, wasmtime_path, arch_str
    );
    iter_dirs(path, wasmtime_path, arch_str).expect("Error loading test files");
}
