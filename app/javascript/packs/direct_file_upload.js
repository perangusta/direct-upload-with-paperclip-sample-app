import $ from 'jquery'
import 'jquery-ui/ui/widget'
import "blueimp-file-upload/js/jquery.iframe-transport.js";
import "blueimp-file-upload/js/jquery.fileupload.js";

function directFileUpload() {
  const form = $(this)
  const input = form.find('input[type="file"]')
  const files = input.prop("files")

  function obtainPresignedURL(file) {
    $.ajax({
      url: "/direct_file_uploads",
      method: "POST",
      cache: false,
      dataType: "json",
      data: {
        authenticity_token: form.find('input[name="authenticity_token"]').val(),
        file: {
          name: file.name,
          type: file.type
        }
      },
      error: function () {
        alert('An error occured')
      },
      success: function (data) {
        uploadFileThroughPresignedURL(file, data.upload_url, data.upload_key)
      }
    })
  }

  function uploadFileThroughPresignedURL(file, upload_url, upload_key) {
    const tmp_form = form.clone();

    tmp_form.fileupload({
      fileInput: null,
      url: upload_url,
      type: "PUT",
      autoUpload: false,
      multipart: false,
      paramName: "file", // S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType: "XML",   // S3 returns XML if success_action_status is set to 201,
      beforeSend: function(xhr) {
        xhr.setRequestHeader("Content-Type", file.type)
      },
      fail: function () {
        alert('An error occured')
      },
      done: function() {
        requestRecordCreation(upload_key)
      }
    })

    tmp_form.fileupload('send', { files: [file] })
  }

  function requestRecordCreation(upload_key) {
    $.ajax({
      url: form.attr('action'),
      cache: false,
      method: "POST",
      dataType: "json",
      data: {
        authenticity_token: form.find('input[name="authenticity_token"]').val(),
        upload_key: upload_key,
        attachment: {
          attachable_type: form.find('input[name="attachment[attachable_type]"]').val(),
          attachable_id: form.find('input[name="attachment[attachable_id]"]').val()
        }
      },
      error: function () {
        alert('An error occured')
      },
      success: function () {
        alert('OK');
      }
    })
  }

  if(files.length == 0) {
    alert('Please select at least one file')
  } else {
    $.each(files, function (index, file) {
      obtainPresignedURL(file)
    })
  }

  return false;
}

$(document).ready(function() {
  $('form[data-direct-file-upload="true"]').on('submit', directFileUpload)
});
