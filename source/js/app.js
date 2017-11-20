let config = require('../../build.config.json');

import Unsplash, { toJson } from 'unsplash-js';
// import riot from 'riot';
window.riot = require('riot');
// window.material = require('../../bower_components/material-design-lite/material.min.js');



window.unsplash = new Unsplash({
	applicationId: config.API.id,
	secret: config.API.secret
});

window.unsplash.toJson = function(res) {
	return typeof res.json === "function" ? res.json() : res;
};