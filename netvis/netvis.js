function showGraph(viscontainer, id, type) {
  const sourceurl = `entity-as-graph.xql?id=${id}&type=${type}`;
  const visCard = document.getElementById(viscontainer);
  var spinner = new Spinner().spin();

  const render = graph => {
    ReactDOM.render(
      React.createElement(NetworkVisualization.Visualization, {
        graph,
        dimensions: 2,
        children: props => [
            React.createElement(NetworkVisualization.ExportButton, props),
            React.createElement(NetworkVisualization.Legend, props)
        ],
        onNodeClick: ({
          node
        }) => {
          console.log(node);
          if (!node) {
            console.error("No node found");
            return;
          }
          const url = node.as_graph;
          if (!url) {
            console.error("No URL found");
            return;
          }
          visCard.appendChild(spinner.el);
          fetch(url)
            .then(response => response.json())
            .then(graph => {
              visCard.removeChild(spinner.el);
              return render(graph)
            })
            .catch(error => {
              console.error(error)
            });
        }
      }),
      document.getElementById(viscontainer)
    );
  };

  visCard.appendChild(spinner.el);
  fetch(sourceurl)
    .then(response => response.json())
    .then(graph => {
      const toArray = prop => Array.isArray(prop) ? prop : [prop]
      return {
        nodes: toArray(graph.nodes || []),
        edges: toArray(graph.edges || []),
        types: {
          nodes: toArray(graph.types.nodes || []),
          edges: toArray(graph.types.edges || []),
        }
      }
    })
    .then(render)
    .catch(error => {
      // handle your errors here
      console.error(error);
    });
}
