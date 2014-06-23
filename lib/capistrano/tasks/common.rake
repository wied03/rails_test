def shred_file(filename)
  execute :shred,
          '-n',
          20,
          '-z',
          '-u',
          filename,
          '||',
          'true'
end