from pydot import graph_from_dot_data
from re import sub
from sys import argv

def read_contents(path:str) -> str:
  contents=''
  with open(path) as f:
    contents=f.read()
    f.close()
  return contents

def normalize_gviz(gviz:str) -> str:
  # For some reason, melos outputs ";" inside the "[]"
  # instead of "," so we reformat with regex:
  return sub(r'(\[.*)(\;)(.*\])', r'\1,\3', gviz)

def remove_subgraphs(gviz:str) -> str:
  # Remove subgraphs (module groupings)
  idx = gviz.find('subgraph')
  gviz = gviz[:idx] # Everything before the first reference of 'subgraph'
  gviz += '}\n' # Close the graph
  return gviz

def write_svg(gviz:str, path:str) -> None:
  graphs = graph_from_dot_data(gviz)
  print('len(graphs):', len(graphs))
  graphs[0].write(path, prog='dot', format='svg')

def main():
  if len(argv) != 3:
    print('Usage: python package_tree.py <path-to-graphviz-file> <path-to-output-directory>')
  gviz = normalize_gviz(read_contents(argv[1]))
  print(gviz)
  write_svg(gviz, argv[2]+'/package_tree_by_module.svg')
  gviz=remove_subgraphs(gviz)
  print(gviz)
  write_svg(gviz, argv[2]+'/package_tree_hierarchical.svg')

if __name__ == '__main__':
  main()