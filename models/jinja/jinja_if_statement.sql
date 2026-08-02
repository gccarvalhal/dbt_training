{# this indicates some sort of operation is happening inside the Jinja context.
   It will be invisible to the end user after the code is compiled into whatever
   you are outputting. #}

{% set temperature = 60.0 %}
'On a day like this'
{# this indicates that we are pulling something out of the jinja context and
actually printing it into the file we are interacting with, in order to
produce some sort of written material #}

{% if temperature > 70 %}
'a refreshing lemon sorbet'
{% else %}
'a decadent chocolate cake'
{% endif %}