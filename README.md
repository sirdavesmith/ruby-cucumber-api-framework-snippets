## Ruby Cucumber API Framework Snippets

Collection of snippets that suggest ideas for how a Cucumber API testing framework could look

Note: These are just snippets for demo purposes - this project won't run 

#### Assumptions
- These snippets were written for a RESTful Ruby API
- They would live in the same repo as the app under test
- Ruby, Rails, Bundler, Cucumber, Runner, RSpec, Specr, Docker, Jenkins

#### General Suggestions

Consider using a [runner](http://ryanstutorials.net/bash-scripting-tutorial/bash-script.php) for enhanced test configuration and execution options.

Tests should not depend on the app being in a specific state. Setup or cleanup should happen outside of your tests.
