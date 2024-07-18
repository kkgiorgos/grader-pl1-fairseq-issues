import sys
import subprocess
import argparse
import filecmp
from time import perf_counter
import resource

def assert_test(index, output, cpu_time):
    comparison = filecmp.cmp(output, "output.txt")
    text = {True: "passed!", False: "failed :("} [comparison]
    print(f'Test {index} has {text} in {cpu_time:.2f} seconds.')
    if not comparison:
        with open(output, "r") as exp, open("output.txt", "r") as real:
            print('Expected output:')
            print(exp.read())
            print('got:')
            print(real.read())

 
parser = argparse.ArgumentParser(
                    prog='evaluate',
                    description='Checks the inputed executable for correctness against a pre created test suite for fairseq')

parser.add_argument('executable')
parser.add_argument('suite')
args = parser.parse_args()

inputs = []
outputs = []
isInput = True
with open(args.suite, "r") as test_suite:
    for line in test_suite:
        if line[:-1] == '----':
            isInput = False
            continue
        if isInput:
            inputs.append(line[:-1])
        else:
            outputs.append(line[:-1])

index = 1
for input,output in zip(inputs,outputs):
    with open('output.txt', "w") as outfile:
        usage_start = resource.getrusage(resource.RUSAGE_CHILDREN)
        subprocess.run(['./'+args.executable, input], stdout=outfile)
        usage_end = resource.getrusage(resource.RUSAGE_CHILDREN)
        cpu_time = usage_end.ru_utime - usage_start.ru_utime
    assert_test(index, output, cpu_time)
    index += 1