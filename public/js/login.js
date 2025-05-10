$(document).ready(
    function() {
        // login is submitted
        $("form#loginForm").submit(
            function() {
                var username = $('#username').attr('value'); // get username
                var password = $('#password').attr('value'); // get password

                // check if username and password are empty
                if (username && password) {
                    // process them
                    $.ajax(
                        {
                            type: "GET",
                            url: "cgi-bin/login.pl",
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            // send username and password as parameters to the Perl script
                            data: "username=" + username + "&password=" + password,
                            // script call was *not* successful
                            error: function(XMLHttpRequest, textStatus, errorThrown) { 
                                $('div#loginResult').text("responseText: " + XMLHttpRequest.responseText 
                                    + ", textStatus: " + textStatus 
                                    + ", errorThrown: " + errorThrown);
                                $('div#loginResult').addClass("error");
                            },
                            // script call was successful 
                            // data contains the JSON values returned by the Perl script 
                            success: function(data) {
                                if (data.error) {
                                    $('div#loginResult').text("data.error: " + data.error);
                                    $('div#loginResult').addClass("error");
                                } else {
                                    $('form#loginForm').hide();
                                    $('div#loginResult').text("data.success: " + "data.username: ", data.username);
                                    $('div#loginResult').addClass("success");
                                }
                            }
                        }
                    );
                } else {
                    // no joy, return with error
                    $('div#loginResult').text("enter username and password");
                    $('div#loginResult').addClass("error");
                }
                $('div#loginResult').fadeIn();
                return false;
            }
        );
    }
);
