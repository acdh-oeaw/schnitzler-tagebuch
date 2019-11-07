const visCard = document.getElementById('visualization')
var spinner = new Spinner().spin();

const render = graph => {
    ReactDOM.render(
        React.createElement(NetworkVisualization.Visualization, {
            graph,
            dimensions: 2,
            children: props => React.createElement(NetworkVisualization.ExportButton, props),
            onNodeClick: ({
                node
            }) => {
                console.log(node)
                if (!node) {
                    console.error('No node found')
                    return
                }
                const url = node.as_graph
                if (!url) {
                    console.error('No URL found')
                    return
                }
                fetch(url).then(response => response.json()).then(render).catch(error => console.error(error))
            }

        }),
        document.getElementById('visualization')
    )
}

visCard.appendChild(spinner.el);
fetch("http://127.0.0.1:8080/exist/apps/schnitzler-tagebuch/netvis/tei-as-graph.xql")
    .then(response => response.json())
    .then(console.log('HALLO'))
    .then(render)
    .catch((error) => {
        // handle your errors here
        console.error(error)
    })