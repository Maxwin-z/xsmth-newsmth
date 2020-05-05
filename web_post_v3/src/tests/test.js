function main() {
  const a = Math.ceil(Math.random() * 10);
  const b = Math.ceil(Math.random() * 20);

  const nums = [];
  for (let i = 0; i < 5; ++i) {
    nums.push(a * i + b);
  }

  console.log(nums.join(",\t") + ",\t___" + ", ... , (30) ___");
}

for (let i = 0; i < 20; ++i) {
  main();
}
