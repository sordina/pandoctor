
Pandoctor allows you to process the contents of pandoc code-blocks with a script.

<img src="https://raw.github.com/sordina/pandoctor/master/trust-me-im-a-doctor.jpg" alt="trust me... i'm a doctor" />

Example Markdown:


For example, if you wanted to render a graph with graphviz...

```

## Graphs

Here is a cool graph:

~~~{data-filter=./resources/scripts/graph.sh data-output=resources/images/graphs/n1.png .hidden}
digraph {
  rankdir=LR;
  a; b; c; d; e; f; g; h; i;
  a -> d; a -> e;
  b -> d; b -> e;
  c -> d; c -> e;
  d -> f; d -> g; d -> h; d -> i;
  e -> f; e -> g; e -> h; e -> i;
}
\~~~

```

Usage:

    > pandoctor < some_markdown.md

Binaries:

* <http://sordina.binaries.s3.amazonaws.com/pandoctor-0.1.0.0-MacOSX-10.9.5-13F34.zip>
