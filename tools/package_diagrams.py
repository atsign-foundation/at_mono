from pydot import graph_from_dot_data
from re import sub, findall
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
  svg = graphs[0].create(prog='dot', format='svg').decode('ascii')
  svg = autoscale_svg(svg)
  with open(path, 'w') as f:
    f.write(svg)
    f.close()

def autoscale_svg(svg:str) -> str:
  scale_regex = r'scale\([\d\.]* [\d\.]*\)'

  vb_regex = r'viewBox="[\d\.]* [\d\.]* ([\d\.]*) ([\d\.]*)"'
  bg_regex = r'<polygon fill="white" stroke="transparent" points="([\-\d\.]*),([\-\d\.]*) [\-\d\.]*,[\-\d\.]* ([\-\d\.]*),([\-\d\.]*) [\-\d\.]*,[\-\d\.]* [\-\d\.]*,[\-\d\.]*"\/>'

  vb = findall(vb_regex, svg)[0]
  bg = findall(bg_regex, svg)[0]

  scaled_width = float(bg[2])-float(bg[0])
  scaled_height = float(bg[3])-float(bg[1])

  scale = min(abs(float(vb[0])/scaled_width), abs(float(vb[1])/scaled_height))

  return sub(scale_regex, 'scale({0} {1})'.format(scale, scale), svg)

def main():
  if len(argv) != 3:
    print('Usage: python package_tree.py <path-to-graphviz-file> <path-to-output-directory>')

  gviz = normalize_gviz(read_contents(argv[1]))
  write_svg(gviz, argv[2]+'/package_tree_by_module.svg')
  gviz=remove_subgraphs(gviz)
  write_svg(gviz, argv[2]+'/package_tree_hierarchical.svg')

if __name__ == '__main__':
  main()