$("button").click(function(e) {
    e.preventDefault();
    var endpoint = "https://arche-curation.acdh-dev.oeaw.ac.at/blazegraph/sparql";
    var persId = $(this).attr('data-key');
    var personName = $(this).attr('data-person');
    var resultTitleId = "fetchMentionsModalHeader";
    var resultTitleString = `${personName} wird in folgenden Dokumenten erwähnt:`;
    var resultBody = "fetchMentionsModalBody";
    var sparqlQuery = `PREFIX%20acdh%3A%20%3Chttps%3A%2F%2Fvocabs.acdh.oeaw.ac.at%2Fschema%23%3E%0A%0ASELECT%20%3Ftitle%20%3Facdhid%0AWHERE%20%7B%0A%20%20%3FcurrentActor%20acdh%3AhasIdentifier%20%3Chttps%3A%2F%2Fid.acdh.oeaw.ac.at%2Fschnitzler%2Fschnitzler-tagebuch%2Fpersons%2F${persId}%3E%20.%0A%20%20%3FcurrentActor%20acdh%3AhasIdentifier%20%3Fuuid%20.%0A%20%20%3Feditions%20acdh%3AhasActor%20%3Fuuid%20.%0A%20%20%3Feditions%20acdh%3AhasTitle%20%3Ftitle%20.%0A%20%20%3Feditions%20acdh%3AhasIdentifier%20%3Facdhid%20.%0A%20%20FILTER%20regex%28str%28%3Facdhid%29%2C%20%22entry__%22%2C%20%22i%22%20%29%0A%7D%0A`;
    var resultShow = "fetchMentionsModal";

    fetchMentions(endpoint, sparqlQuery, resultTitleId, resultTitleString, resultBody, resultShow)
});

function fetchMentions(endpoint, sparqlQuery, resultTitleId, resultTitleString, resultBody, resultShow) {

    var settings = {
        url: endpoint,
        async: true,
        crossDomain: true,
        method: "GET",
        data: {
            query: decodeURIComponent(sparqlQuery),
            format: "json"
        }
    };

    $.ajax(settings).done(function(response) {
        var mentionsAmount = response.results.bindings.length;
        const list = response.results.bindings.map(function(item) {
            return `<li><a href='${item.acdhid.value}'>${item.title.value}</a></li>`
        })

        document.querySelector(`#${resultTitleId}`).innerHTML = resultTitleString;
        document.querySelector(`#${resultBody}`).innerHTML = `<ul>${list}</ul>`
        $(`#${resultShow}`).modal('show');
    });
}
