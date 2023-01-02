# Sample API Automation Suite done using Karate

The sample cases in this suite are done for vonage's conversation APIs avaialble @ https://developer.nexmo.com/api/conversation

A copy the these Vonage api definitions can also be found at this project's root folder : ./conversation.yml

To run this suite we need JWT tokens that can be generated form : https://developer.vonage.com/jwt

To get the application id and private key, you need to 
<br>
<pre>
sign up -> applications -> create an application -> private key will be downloaded to the local and APP key will be available in the UI
</pre>

paste the above generate JWT in karate-config file's "auth" variable, Now the suite is ready for execution 

<h3>Command to Run the tests: </h3>
<pre> mvn test -Dtest=TestRunner </pre>

<h3>Command options:</h3>

<h5>-Dkarate.env </h5>
To send environment name <br>
<h4>eg:</h4>
<pre> mvn test -Dtest=TestRunner -Dkarate.env=staging <br>
 mvn test -Dtest=TestRunner -Dkarate.env=demo </pre><br>


<h5>-Durl </h5> 
To pass url directly instead of environment name <br>
<h4>eg:</h4>
<pre> mvn test -Dtest=TestRunner -Durl=https://sample.com/api/ <br>
 mvn test -Dtest=TestRunner -Durl=https://sample.com/api/ </pre><br>


<h5>-DthreadCount</h5> To config the no of threads in which the cases can run <br>
<h4>eg:</h4>
<pre> mvn test -Dtest=TestRunner -DthreadCount=5 </pre><br>


<h5>-Dfeatures </h5>To config the list of feature files need to be executed <br>
<h4>eg:</h4>
<pre> mvn test -Dtest=TestRunner -Dfeatures=path/to/fileOne.feature,path/to/package </pre><br>


<h5>-DreportPath</h5> To config custom path to generate karate report<br>
<h4>eg:</h4>
<pre> mvn test -Dtest=TestRunner -DreportPath=custom/path </pre><br>


<h4>eg:</h4>
<pre> mvn test -Dtest=TestRunner -DthreadCount=5 -Dfeatures=path/to/fileOne.feature,path/to/package -DreportPath=custom/path</pre>

<b>Reference Link:</b> <br>
https://github.com/karatelabs/karate