jQuery ->

  uploaderHost = 'http://do2-media.s3.amazonaws.com'

  xhrUploadProgressSupported = () ->
    xhr = new XMLHttpRequest()
    xhr && ('upload' of xhr) && ('onprogress' of xhr.upload)


  # Can only track progress if size property is present on files.
  progressSupported = xhrUploadProgressSupported()


  $('#uploading_files').on 'click', '.uploading_file .remove_link', (e) ->
    uuid = $(this).parent().attr('id')
    $(this).parent().remove()
    $('#uploader iframe')[0].contentWindow.postMessage({ eventType: 'abort upload', uuid: uuid }, uploaderHost);


  $(window).bind "message", (event) ->

    event = event.originalEvent

    if event.origin != uploaderHost
      return

    eventType = event.data.eventType;
    delete event.data.eventType;

    data = event.data

    switch eventType

      when 'upload done'

        $(".uploading_file[data-uuid=#{data.uuid}]").remove()

        $.ajax $('#uploader iframe').data('create-resource-url'),
          type: 'POST',
          data: data


      when 'add upload'

        if progressSupported
          uploadPercent = "<br/><progress value='0' max='100' class='upload_progress_bar'>0</progress> <span class='upload_percentage'>0</span> %";
          $('#uploading_files').append("<p class='uploading_file'>#{data.file_name + uploadPercent} <a href='#' class='remove_link'>X<a/></p>");
        else
          $('#uploading_files').append("<p class='uploading_file'>#{data.file_name}<br/><img src='img/uploading.gif'/></p>");

        $('.uploading_file').last().attr 'data-uuid', data.uuid


      when 'upload progress'

        if progressSupported
          $(".uploading_file[data-uuid=#{data.uuid}]").find('.upload_percentage').html(data.progress)
          $(".uploading_file[data-uuid=#{data.uuid}]").find('.upload_progress_bar').val(data.progress)

