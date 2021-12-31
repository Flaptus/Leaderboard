function changePage(page) {
	fetch("/api/leaderboard")
		.then(r => r.json())
		.then(scores => {
			document.querySelectorAll("tr:not(:first-child):not(:last-child)").forEach(row => row.remove());

			const table = document.querySelector("tbody");
			const pageChanger = document.querySelector("tr:last-child");
			for (let i = 10*(page-1); i < 10*page && i < scores.length; i++) {
				const row = document.createElement("tr")

				const rank = document.createElement("td");
				rank.innerText = i+1 + ".";

				const username = document.createElement("td");
				username.innerText = scores[i]["username"];

				const score = document.createElement("td");
				score.innerText = scores[i]["score"];

				row.append(rank);
				row.append(username);
				row.append(score);
				
				table.insertBefore(row, pageChanger);

				document.querySelector("tr span").innerText = "Page " + page + " of " + Math.ceil(scores.length/10);
			}
		});
}

window.onload = () => {
	let page = 1;

	document.querySelector("#left").addEventListener("click", () => {
		if (page > 1) changePage(--page);
	});
	document.querySelector("#right").addEventListener("click", () => {
		let splitText = document.querySelector("tr span").innerText.split(" ")
		let maxLength = splitText[splitText.length-1]

		if (page < maxLength) changePage(++page);
	});
}